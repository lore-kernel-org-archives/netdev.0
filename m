From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 13 Sep 2002 15:12:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1031955140.3d8262c4c1de9@imap.linux.ibm.com>
References: <Pine.LNX.4.44.0209131553510.10203-100000@gp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: tcw@tempest.prismnet.com, pfeather@cs.unm.edu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, todd-lkml@osogrande.com
In-Reply-To: <Pine.LNX.4.44.0209131553510.10203-100000@gp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting todd-lkml@osogrande.com:

> dave, all,
> 
> not sure i understand what you're proposing, but while we're at it,
> why not also make the api for apps to allocate a buffer in userland
> that (for nics that support it) the nic can dma directly into?  it

I believe thats exactly what David was referring to - reverse
direction sendfile() so to speak.. 

> seems likely notification that the buffer was used would have to
> travel through the kernel, but it would be nice to save the
> interrupts altogether. 

However, I dont think what youre saving are interrupts as 
much as the extra copy, but I could be wrong..

thanks,
Nivedita
