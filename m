From: Pankaj Thakkar <pthakkar@vmware.com>
Subject: RE: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 14 Jul 2010 10:18:22 -0700
Message-ID: <F1354E79A137A24CBA60059AA65CB1B802A34EEB67@EXCH-MBX-2.vmware.com>
References: <20100504230225.GP8323@vmware.com>
	<201005051029.42052.dtor@vmware.com>
	<20100505173120.GA1752@infradead.org>
	<201005051035.29831.dtor@vmware.com>
	<20100505173951.GA8388@infradead.org>
	<20100505105253.0a8bc465@nehalam>
	<20100506202113.GC17922@infradead.org>
	<1278990388.32650.22.camel@eng-rhel5-64>,
	<20100714094952.GA16209@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>,
        Stephen Hemminger <shemminger@vyatta.com>
To: Greg KH <greg@kroah.com>, Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20100714094952.GA16209@kroah.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The plugin is guest agnostic and hence we did not want to rely on any kernel provided functions. The plugin uses only the interface provided by the shell. The assumption is that since the plugin is really simple and straight forward (all the control/init complexity lies in the PF driver in the hypervisor) we should be able to get by for most of the things and for things like memcpy/memset the plugin can write simple functions like this.


-p


________________________________________
From: Greg KH [greg@kroah.com]
Sent: Wednesday, July 14, 2010 2:49 AM
To: Shreyas Bhatewara
Cc: Christoph Hellwig; Stephen Hemminger; Pankaj Thakkar; pv-drivers@vmware.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; virtualization@lists.linux-foundation.org
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3


Is there some reason that our in-kernel functions that do this type of
logic are not working for you to require you to reimplement this?

thanks,

greg k-h
