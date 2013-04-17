From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [Patch net-next v4 3/5] vxlan: add ipv6 support
Date: Wed, 17 Apr 2013 19:34:51 +0300
Message-ID: <CAF1J0HN3v7dFX_37ju6=j3nFq7UvOssKZ=NpHctdJy1nPAGfSw@mail.gmail.com>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	<1366175423-27310-4-git-send-email-amwang@redhat.com>
	<CAF1J0HOYVCe-0MVE6-mxyjEOaEAWNR16Wpv7+CF6rxbEgBQ3GA@mail.gmail.com>
	<1366192640.700.3.camel@cr0>
	<CAF1J0HNu9i_N2AtxvKL=edsVbZpZCsJL0mh2HEfF2G28CYcHYA@mail.gmail.com>
	<1366204692.700.8.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog104.obsmtp.com ([74.125.245.76]:37009 "HELO
	na3sys010aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751160Ab3DQQex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:34:53 -0400
Received: by mail-oa0-f71.google.com with SMTP id o17so10636860oag.2
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 09:34:51 -0700 (PDT)
In-Reply-To: <1366204692.700.8.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 17, 2013 at 4:18 PM, Cong Wang <amwang@redhat.com> wrote:
> On Wed, 2013-04-17 at 13:36 +0300, Mike Rapoport wrote:
>> Well, I think that the address comparison helpers,
>> vxlan_nla_{get,put}_addr, vxlan_newlink and vxlan_fill_info can be
>> left with run-time checks only. Maybe some other places as well.
>> Removing the ifdefs will increase compile time for kernels configured
>> with IPV6=n, and may have certain run-time performance impact for such
>> kernels. On the other hand, less ifdefs means better readability :).
>
> In theory, yes; in this case, I don't think having these ifdefs harms
> the readability.
>

IMHO, the less ifdefs the better, but I can live with them as well :)


-- 
Sincerely yours,
Mike.
