From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] vxlan: Use RCU apis to access sk_user_data.
Date: Tue, 24 Sep 2013 09:27:41 -0700
Message-ID: <CALnjE+qvkix37P58Mz86DsaJayFEoEfvf9YXYFnkryOc3Ro5pw@mail.gmail.com>
References: <1380000501-13969-1-git-send-email-pshelar@nicira.com>
	<20130924092050.2c80bc74@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:33232 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753912Ab3IXQ1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:27:48 -0400
Received: by mail-qc0-f181.google.com with SMTP id q4so3234723qcx.26
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:27:43 -0700 (PDT)
In-Reply-To: <20130924092050.2c80bc74@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 9:20 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon, 23 Sep 2013 22:28:21 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>>
>> +#define sk_user_data_rcu(sk) ((*((void __rcu **)&(sk)->sk_user_data)))
>
> I don't like the macro, is it just to keep sparse happy?
yes, it is for sparse.
> The name also implies that rcu_dereference() is built in.
ok, I can right separate API for rcu-set and rcu-deref.
