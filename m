From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/1] veth: don't free priv->status until dev->destructor (v2)
Date: Wed, 05 Aug 2009 15:43:34 -0700
Message-ID: <m1vdl1x4o9.fsf@fess.ebiederm.org>
References: <20090626162418.GA24828@us.ibm.com>
	<20090724124614.6acc5054@nehalam> <m1zlaeu5jk.fsf@fess.ebiederm.org>
	<20090805101005.6a02f0ae@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Sachin Sant <sachinp@in.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, matthltc@us.ibm.com,
	lkml <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753448AbZHEWnp@vger.kernel.org>
In-Reply-To: <20090805101005.6a02f0ae@nehalam> (Stephen Hemminger's message of "Wed\, 5 Aug 2009 10\:10\:05 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@vyatta.com> writes:
>
> Sysfs must be safer than it used to be. 

Definitely.  A lot of this dates to Tejun's cleanups which merged
2-3 years agos now.  Just before I started working on sysfs.

Eric
