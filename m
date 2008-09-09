From: "Eugene Teo" <eugeneteo@kernel.sg>
Subject: Re: Internet-Draft on Port Randomisation
Date: Tue, 9 Sep 2008 14:31:19 +0800
Message-ID: <28fa9c5e0809082331g33ca66a4se49ed11b3e037c0b@mail.gmail.com>
References: <28fa9c5e0809082107p7a33dc4fod344fde212e1d710@mail.gmail.com>
	 <48C60284.2070402@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:62165 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820AbYIIGbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 02:31:19 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1776570rvb.1
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 23:31:19 -0700 (PDT)
In-Reply-To: <48C60284.2070402@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 9, 2008 at 12:58 PM, Stephen Hemminger
<stephen.hemminger@vyatta.com> wrote:
> Eugene Teo wrote:
>>
>> Has anyone read this Internet-Draft?
>>
>> http://www.gont.com.ar/drafts/port-randomization/draft-ietf-tsvwg-port-randomization-02.txt
>>
>> In this memo, there are descriptions of four different ephemeral port
>> randomisation algorithms (see page 17).
>>
>> Algo #1 and #2 are simple port randomisation algorithms. Algo #3 is
>> what we have in Linux. The memo suggested algorithm #4, double-hash
>> randomisation algorithm, which is an improvement to algo #3 (see page
>> 15).
>>
>> Does anyone have any thought about the improved algorithm? Is this
>> worth implementing,
>
> No the added lock overhead of a global next free port array is not worth it.
> Think of big web server under
> DoS pressure. The existing port search can run in parallel, Algo #4 was
> suggested by people
> who don't work on a real SMP OS.

Thanks Stephen.

Eugene
