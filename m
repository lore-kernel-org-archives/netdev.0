From: Mark Doffman <mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Subject: Re: [PATCH 0/4] Add ceph root filesystem functionality and documentation.
Date: Fri, 22 Nov 2013 10:53:21 -0600
Message-ID: <528F8C01.8020603@codethink.co.uk>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk> <1385065186.18238.0.camel@frustration.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rob.taylor-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org
To: David Dillow <dave-i1Mk8JYDVaaSihdK6806/g@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1385065186.18238.0.camel-zHLflQxYYDO4Hhoo1DtQwJ9G+ZOsUmrO@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/21/2013 02:19 PM, David Dillow wrote:
> On Wed, 2013-11-20 at 20:13 -0600, mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org wrote:
>> The following patch series adds the ability to use a ceph distributed
>> file system as the root device. The functionality is similar to
>> NFS root but for the ceph filesystem.
>
> Why do this in the kernel vs in the initramfs? Dracut would be a more
> appropriate place, I think, as it has support for other network root
> devices already.

I don't know if its a good idea to require an initramfs for mounting a
rootfs over the network. NFS root is currently in the kernel, and
frequently used without an initramfs.

Booting from ceph using a root device is relatively simple compared to
generating an initramfs and it has the possibility of producing smaller
images for memory constrained devices.


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
