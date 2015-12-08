From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: MPLS decap with iproute2
Date: Tue, 8 Dec 2015 14:45:40 -0700
Message-ID: <56674F84.1000401@cumulusnetworks.com>
References: <CAJm+voVUXPBXBRo98K6XS9pVEkN=fCJ4chRdQ=azcZO9ge9gEg@mail.gmail.com>
 <5665FD5A.8000200@brocade.com>
 <CAJm+voWbsySEHxT=nmokbxz4fiqyfAhmJSQNgi9YApen3OKRag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sam Russell <sam.h.russell@gmail.com>,
	Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34141 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbLHVpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 16:45:46 -0500
Received: by pacwq6 with SMTP id wq6so18056287pac.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 13:45:46 -0800 (PST)
In-Reply-To: <CAJm+voWbsySEHxT=nmokbxz4fiqyfAhmJSQNgi9YApen3OKRag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/7/15 2:50 PM, Sam Russell wrote:
> Hi Robert,
>
> Thanks for the tip, I'll give it a shot when I get home this evening (UTC+13).
> I'm planning to put together a blog on how to manually string up an
> MPLS l3vpn, to help people start playing with the new MPLS support now
> that it's finally in the mainline kernel.
>

FWIW, I have demo of this topology with MPLS + VRFs for the VRF tutorial 
at netdev1.1:

h       +--------+                                    +--------+      h
o  -----|        |                                    |        |----- o
s   ... |  c1e1  |-----+                        +-----|  c1e2  | ...  s
t  -----|        |     |                        |     |        |----- t
s       +--------+     |                        |     +--------+      s
                     +-------+              +-------+
                     |       |   +------+   |       |
                     |  pe1  |---|  pe  |---|  pe2  |
                     |       |   +------+   |       |
                     +-------+              +-------+
h       +--------+     |                        |     +--------+      h
o  -----|        |     |                        |     |        |----- o
s   ... |  c2e1  |-----+                        +-----|  c2e2  | ...  s
t  -----|        |                                    |        |----- t
s       +--------+      \----------------------/      +--------+      s
                            provider backbone
