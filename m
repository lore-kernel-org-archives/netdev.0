From: Dan Aloni <da-x@monatomic.org>
Subject: Re: workaround large MTU and N-order allocation failures
Date: Tue, 20 Sep 2005 17:25:09 +0300
Message-ID: <20050920142509.GA26617@localdomain>
References: <20050918143526.GA24181@localdomain> <20050918230822.GA5440@electric-eye.fr.zoreil.com> <20050919071358.GA7107@localdomain> <5fc59ff305091910252447d363@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Kernel List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965020AbVITOVz@vger.kernel.org>
To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Content-Disposition: inline
In-Reply-To: <5fc59ff305091910252447d363@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2005 at 10:25:29AM -0700, Ganesh Venkatesan wrote:
> 82546GB supports an incoming Rx packet to be received in multiple rx
> buffers. A driver that enables this feature is under test currently.
> What version of the e1000 are you using?

We are currently using the lastest version of the driver from the 2.6 
tree backported to the 2.4 tree. I wasn't aware that 82546GB supports 
this - I inferred differently from the comments in the driver's source.

Is the version of the driver you mention available from CVS somewhere?

-- 
Dan Aloni
da-x@monatomic.org, da-x@colinux.org, da-x@gmx.net
