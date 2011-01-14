From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: STMMAC driver: NFS Problem on 2.6.37
Date: Fri, 14 Jan 2011 10:35:11 -0500
Message-ID: <593F2676-CA62-4D77-90AD-41F2FAF13EB6@oracle.com>
References: <4D2EC133.7010607@st.com> <2D04CF75-CA68-4BDC-99A3-FA1DD6113602@oracle.com> <4D2F4453.4040400@st.com> <4D301DD1.9070104@st.com>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Armando VISCONTI <armando.visconti-qxv4g6HH51o@public.gmane.org>,
	"Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shiraz HASHIM <shiraz.hashim-qxv4g6HH51o@public.gmane.org>,
	Viresh KUMAR <viresh.kumar-qxv4g6HH51o@public.gmane.org>,
	Peppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	Amit GOEL <amit.goel-qxv4g6HH51o@public.gmane.org>
To: deepaksi <deepak.sikri-qxv4g6HH51o@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D301DD1.9070104-qxv4g6HH51o@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Jan 14, 2011, at 4:56 AM, deepaksi wrote:

> The nfs work fine when you use the dhcp server, but still it is a
> totally different proposition. The problem comes when we assign a static
> IP in the bootargs, and then try to boot the system using NFS. here is
> the bootargs setting at the u-boot.
> 
> bootargs = console=ttyAMA0,115200 mem=128M root=/dev/nfs
> nfsroot=192.168.1.1:/opt/STM/STLinux-2.3/devkit/arm/target
> ip=192.168.1.10:192.168.1.1:192.168.1.1:255.255.255.0::eth0
> 
> These settings have been working fine for earlier kernels. The tcp dump
> while doing the nfs boot is quite different between the 2.6.32 and
> 2.6.37 kernels.

Have you tried any kernel versions between 2.6.32 and 2.6.37?  I made significant changes in 2.6.36, so it would be helpful to know when this stopped working.

Also, in 2.6.36, I added a new debugging feature for NFSROOT.  See "nfsrootdebug" description in Documentation/filesystems/nfs/nfsroot.txt.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
