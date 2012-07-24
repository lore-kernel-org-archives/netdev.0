From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 00/17] drivers: hv: kvp
Date: Tue, 24 Jul 2012 08:54:12 -0700
Message-ID: <20120724155412.GA23918@kroah.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	virtualization@lists.osdl.org, olaf@aepfle.de, apw@canonical.com,
	netdev@vger.kernel.org, ben@decadent.org.uk
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1343145672-3641-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2012 at 09:01:12AM -0700, K. Y. Srinivasan wrote:
> This patchset expands the KVP (Key Value Pair) functionality to
> implement the mechanism to GET/SET IP addresses in the guest. This
> functionality is used in Windows Server 2012 to implement VM
> replication functionality. The way IP configuration information
> is managed is distro specific. Based on the feedback I have gotten
> from Olaf, Greg, Steve, Ben and Mairus, I have chosen to seperate
> distro specific code from this patch-set. Most of the GET operation
> can be implemented in a way that is completely distro independent and
> I have implemented that as such and is included in this patch-set.
> Some of the attributes that can only be fetched in a distro
> dependent way as well the mechanism for configuring an interface
> (the SET operation) that is clearly distro specific is to be
> implemented via external scripts that will be invoked via the KVP
> code. We define here the interface to these scripts.
> 
> Adding support for IP injection resulted in some changes to the
> protocol between the user level daemon and the kernel driver.
> These changes have been implemented in way that would retain
> compatibility with older daemons. I would like to thank Olaf and
> Greg for pointing out the compatibility issue.

Due to this being the middle of the merge window, I will not be able to
look at this until after 3.6-rc1 is out.

greg k-h
