From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [Intel-wired-lan] NULL dereference on v4.1.x while enabling VF
Date: Mon, 2 May 2016 21:33:26 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF2228664691EA68EC@ORSMSX116.amr.corp.intel.com>
References: <CAJ75kXZV32hLzYY-dynYAj6NHm2xNoq89inmSSbqUyxPvUazEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alex Duyck <aduyck@mirantis.com>
To: William Dauchy <wdauchy@gmail.com>,
	NETDEV <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:43702 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754953AbcEBVd2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 17:33:28 -0400
In-Reply-To: <CAJ75kXZV32hLzYY-dynYAj6NHm2xNoq89inmSSbqUyxPvUazEw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of William Dauchy
> Sent: Monday, May 02, 2016 1:26 PM
> To: NETDEV <netdev@vger.kernel.org>; intel-wired-lan@lists.osuosl.org
> Cc: Alex Duyck <aduyck@mirantis.com>
> Subject: [Intel-wired-lan] NULL dereference on v4.1.x while enabling VF
> 
> Hello,
> 
> I am getting a NULL dereference on v4.1.x while enabling VF on a ixgbe (
> Intel Corporation 82599ES 10-Gigabit) card during boot.
> It seems to be related to a race since I don't have the issue if I test it a few
> seconds after boot. I had the same issue while testing on v4.5.x What can I
> do to help debug the issue?
> 
> ip link set dev eth0 up
> echo 32 > /sys/class/net/eth0/device/sriov_numvfs

Hey William,

Thanks for reporting the dereference.  Could you provide a little more detail on how you created this issue?  Are you just running the two commands (ip, sriov_numvfs) in some rc script and if you put a few second sleep in front of it you don't see the failure?

Thanks,
-Don Skidmore <donald.c.skidmore@intel.com>
