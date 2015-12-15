From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] ser_gigaset: fic deallocation of platform device
 structure
Date: Tue, 15 Dec 2015 13:24:39 -0500 (EST)
Message-ID: <20151215.132439.2249620841169077570.davem@davemloft.net>
References: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tilman@imap.cc, alan@linux.intel.com,
	sasha.levin@oracle.com, peter@hurleysoftware.com,
	linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450199491-30471-1-git-send-email-pebolle@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 15 Dec 2015 18:11:27 +0100

> Sascha Levin reported that the syzkaller fuzzer triggered a WARNING in
> ser_gigaset (see https://lkml.kernel.org/g/56587467.8050102@oracle.com ). It
> turned out that ser_gigaset has always deallocated its platform device
> structure incorrectly. Tilman submitted the patch that fixes that (3/4) and a
> related cleanup (4/4).
> 
> Tilman also submitted a minor cleanup of some NULL checks (1/4) that prompted
> Alan to turn those checks into WARN_ONs (2/4). If no one hits these WARN_ONs in
> the next couple of releases these WARN_ONs should be removed.

Series applied, thanks Paul.
