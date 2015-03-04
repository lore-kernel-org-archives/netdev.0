From: Michel Machado <michel@digirati.com.br>
Subject: Re: Linux XIA - merge proposal
Date: Tue, 03 Mar 2015 19:14:45 -0500
Message-ID: <54F64E75.8060300@digirati.com.br>
References: <54F5EF6E.9090303@digirati.com.br> <87a8ztwta9.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87a8ztwta9.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

>>     Linux XIA is not yet mature enough for production, but we do think
>> that broader exposure will help us to move forward faster, and get
>> more in tune with the interested community. Thus, we are writing to
>> ask to merge our work into the Linux kernel.
>
> I took a quick glance at the code to see if could figure out what
> you were talking about.   Especialy as I could not find any documents
> on the packet format.  The code does not transmit packets.  All of the
> packet transmit functions are stubs.  I can think of no greater failure
> for a networking protocol.

    I don't know what led you this wrong conclusion, but please let me 
show that is not the case. Section 3.3 of our original paper linked 
below describes the forwarding algorithm as well as the header format.

    https://www.usenix.org/system/files/conference/nsdi12/nsdi12-final13.pdf

    One can find the reference to this paper in our XIA 101 page in our 
wiki:

https://github.com/AltraMayor/XIA-for-Linux/wiki/XIA-101

    The code does transmit packet, you can find function 
__xip_fill_in_hdr() in file net/xia/output.c 
(https://github.com/AltraMayor/XIA-for-Linux/blob/xia/net/xia/output.c) 
that fills out the XIP header, and examples to how set up some 
experiments with our stack are available here:

https://github.com/AltraMayor/XIA-for-Linux/wiki/zFilter-principal
https://github.com/AltraMayor/XIA-for-Linux/wiki/4ID-principals
https://github.com/AltraMayor/XIA-for-Linux/wiki/An-exemplifying-demo

[ ]'s
Michel Machado
