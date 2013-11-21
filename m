From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 0/4] Add ceph root filesystem functionality and
 documentation.
Date: Thu, 21 Nov 2013 15:19:46 -0500
Message-ID: <1385065186.18238.0.camel@frustration.ornl.gov>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ceph-devel@vger.kernel.org, sage@inktank.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, rob.taylor@codethink.co.uk
To: mark.doffman@codethink.co.uk
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-11-20 at 20:13 -0600, mark.doffman@codethink.co.uk wrote:
> The following patch series adds the ability to use a ceph distributed
> file system as the root device. The functionality is similar to
> NFS root but for the ceph filesystem.

Why do this in the kernel vs in the initramfs? Dracut would be a more
appropriate place, I think, as it has support for other network root
devices already.

