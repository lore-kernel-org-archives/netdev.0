From: Andi Kleen <ak@suse.de>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 6 Sep 2002 21:26:19 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020906212619.A28172@wotan.suse.de>
References: <3D78C9BD.5080905@us.ibm.com> <53430559.1031304588@[10.10.2.3]> <3D78E7A5.7050306@us.ibm.com> <20020906202646.A2185@wotan.suse.de> <1031339954.3d78ffb257d22@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Nivedita Singhvi <niv@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <1031339954.3d78ffb257d22@imap.linux.ibm.com>
List-Id: netdev.vger.kernel.org

> If you just wanted to speed things up, you could get the
> clients to specify ports instead of letting the kernel
> cycle through for a free port..:)

Better would be probably to change the kernel to keep a limited
list of free ports in a free list. The grabbing a free port would
be an O(1) operation. 

I'm not entirely sure it is worth it in this case. The locks are
probably the majority of the cost.

-Andi
