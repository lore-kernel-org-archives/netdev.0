From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] ehea: fix might sleep problem
Date: Fri, 04 Jul 2008 08:14:23 -0400
Message-ID: <486E141F.6070108@garzik.org>
References: <200807031618.46087.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, kamalesh@linux.vnet.ibm.com,
	hering2@de.ibm.com
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757004AbYGDMOp@vger.kernel.org>
In-Reply-To: <200807031618.46087.ossthema@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> A mutex has to be replaced by spinlocks as it can be called from
> a context which does not allow sleeping.
> The kzalloc flag GFP_KERNEL has to be replaced by GFP_ATOMIC
> for the same reason.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

applied 1-3 to 2.6.26
