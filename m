From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 802.1q/MTU bug
Date: Wed, 1 Jun 2005 01:44:58 +0200
Message-ID: <20050531234458.GA2023@electric-eye.fr.zoreil.com>
References: <20050530071148.GB1514@electric-eye.fr.zoreil.com> <200505301927.26110.james@grickle.org> <200505311820.41469.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Harr <james@grickle.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200505311820.41469.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> I wonder if this is related to the adapter breaking large frames into
> multiple descriptors.  On normal (non-VLAN) frames, this happens at MTU
> 8169. I wonder if enabling VLAN and jumbo frames (a combination I never
> tried) brings down the threshold to MTU 7200.  

Testing suggests that there is at least a size filtering issue (fixed
in netdev-2.6.git but not in 2.6.11.xx nor in 2.6.12-rc). It is unrelated
to hardware vlan support and happens a few bytes above the MTU on the vlan
device (which is set to the same value as the adapter). Of course different
issues could hide in the dark.

--
Ueimor
