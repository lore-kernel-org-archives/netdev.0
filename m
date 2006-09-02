From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: i not find in the kernel code the code of this command
Date: Sat, 2 Sep 2006 12:04:31 +1200
Message-ID: <5640c7e00609011704v2a1e7c38x1ede5f7b3dc4539f@mail.gmail.com>
References: <003a01c6cdd1$7151c100$0201a8c0@PCFranco>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:62364 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751217AbWIBAEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 20:04:33 -0400
Received: by nf-out-f131.google.com with SMTP id k65so71339nfa
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2006 17:04:32 -0700 (PDT)
To: Franco <franco.daje@virgilio.it>
In-Reply-To: <003a01c6cdd1$7151c100$0201a8c0@PCFranco>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/2/06, Franco <franco.daje@virgilio.it> wrote:
> I thought that this code was police.c but seem that it isn't
> i must implement a proc file in the code and recompiling the kernel.
>
I'm not sure I understand your question. Please tell me if I answer wrong!

The code is under net/sched in the source tree. The main file is
act_police.c but it is in use elsewhere as well. grep for POLICE.

To build the code you need to alter your kernel options under 'make
menuconfig' Networking, Networking Options, Qos and/or fair queueing,
Actions must be selected and then Traffic Police.

I hope this helps.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand

-- 
VGER BF report: U 0.5
