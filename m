From: Steve Chen <schen@mvista.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Thu, 12 Aug 2010 18:04:36 -0500
Message-ID: <AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>
References: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>
	<4C646330.6080303@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:65229 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761100Ab0HLXEj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 19:04:39 -0400
Received: by ywh1 with SMTP id 1so627659ywh.19
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 16:04:39 -0700 (PDT)
In-Reply-To: <4C646330.6080303@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 12, 2010 at 4:10 PM, Brian Haley <brian.haley@hp.com> wrote=
:
> Hi Steve,
>
> On 07/28/2010 11:20 PM, Steve Chen wrote:
>> Hello,
>>
>> The TAHI correspondent node tests CN-6-4-1 (Processing in upper laye=
r
>> - Echo Checksum) failed for me in the 2.6.32 kernel. =A0It appears t=
hat
>> the Linux kernel is replying the ICMP echo request in
>> icmpv6_echo_reply without much checking. =A0Is this an intentional
>> non-conformance to RFC3775 section 9.3.1?
>
> Sorry for the late reply. =A0I've run these tests in the past against
> SLES11 (2.6.27 ?) back in January 2009 and this one passed from looki=
ng
> at my logs. =A0I don't have that system around anymore to check the c=
onfig,
> etc. =A0I didn't see any obvious commit that would have broken it fro=
m a
> quick look, do you have a test setup to do some debugging? =A0It will
> take a little time for me to re-configure mine to run this test.

Brian,

I'm using mip6d from git://www.umip.org/git/umip.git commit id
d1c240f3deb690af902ce1ff128780551ff6141c.  Is that the correct version
to use?  Looking at the kernel code again, the checksum error should
have been caught in icmpv6_rcv.  There are probably something wrong
with my setup.  I'll dig around a bit more.

Tests 5-3-1 to 5-3-6 also failed for me.   Did they pass for you?

Steve
