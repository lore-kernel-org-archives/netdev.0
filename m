From: "Julius Volz" <juliusv@google.com>
Subject: Adding IPv6 support to IPVS: some general questions about kernel development
Date: Mon, 31 Mar 2008 16:53:08 +0200
Message-ID: <f4845fc0803310753o56ccbae5uda1e216fa139857@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:3025 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbYCaOxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 10:53:15 -0400
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m2VEr95T031909
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 15:53:10 +0100
Received: from ik-out-1112.google.com (ikab35.prod.google.com [10.68.53.35])
	by zps76.corp.google.com with ESMTP id m2VEqMGV025655
	for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 07:53:09 -0700
Received: by ik-out-1112.google.com with SMTP id b35so251814ika.7
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2008 07:53:08 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was redirected here from lvs-devel for a particular question. As
part of an internship at Google, I am currently looking at porting the
IPVS (IP virtual server) kernel part of LVS to support IPv6. First
off, I am neither a real specialist in any of the involved areas yet
(IPv6, load balancing) nor do I have much experience writing kernel
code (mainly reading it for some time now), but I will try to learn as
much as I can each day. Do expect lots of newbie questions though ;)

One question I had on lvs-devel that people here might know more
about: IPVS is currently sitting at "net/ipv4/ipvs/..." in the kernel.
A lot of this code would probably be the same for an IPv6 version, so
the code would have to be refactored somehow and partially moved to a
location where it can be used by both the IPv4 and IPv6 code. Are
there any special rules for this and what do I have to think of? For
example, could I just move the common code to a directory "net/ipvs"
(or even all of the code, for both IPv4 and IPv6) or would people
object?

I'm also not sure yet on how to best begin coding in such a manner
that the whole thing will be manageable with small, separate patches
that each have a chance of being accepted (would that mean that each
small patch would have to be useful on its own in a way? That seems
difficult). This is just because I also don't have a lot of experience
patching other people's projects in this manner.

If any of you could offer some advice on these issues, I would greatly
appreciate it!

Kind Regards,
Julius Volz

-- 
Google Switzerland GmbH
