From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] 9p: Don't use ATTR_* values from fs.h in userspace
 facing  structs
Date: Sat, 17 Dec 2011 20:04:27 +0200
Message-ID: <1324145067.4496.44.camel@lappy>
References: <1324134422-16642-1-git-send-email-levinsasha928@gmail.com>
	 <20111217174725.GW2203@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
	davem@davemloft.net, aneesh.kumar@linux.vnet.ibm.com,
	jvrao@linux.vnet.ibm.com, v9fs-developer@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111217174725.GW2203@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-12-17 at 17:47 +0000, Al Viro wrote:
> Look, that's the problem with exposing this stuff to protocol; you don't
> get clear semantics and are you seriously asking for trouble on kernel
> changes.  Suppose tomorrow we get rid of e.g. ATTR_KILL_PRIV; what are you
> guys going to do?  Hope that no 9p server has behaviour dependent on that
> flag being set or cleared?
> 
> Don't turn the kernel internals into a part of ABI.  And blind bulk remapping
> of constants is exactly that... 

I went with Aneesh's suggestion and did something similar to something
9p already has done before.

This is probably a good opportunity to open it up for discussion, since
I currently have a block of code containing those ATTR_* defines
copy-pasted from linux/fs.h in my userspace code, and thats obviously a
serious wtf.

-- 

Sasha.
