From: Yanko Kaneti <yaneti@declera.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Fri, 24 Oct 2014 20:09:31 +0300
Message-ID: <20141024170931.GA21849@declera.com>
References: <20141023122750.GP4977@linux.vnet.ibm.com>
 <20141023153333.GA19278@linux.vnet.ibm.com>
 <20141023195159.GA2331@declera.com>
 <20141023200507.GC4977@linux.vnet.ibm.com>
 <1414100740.2065.2.camel@declera.com>
 <20141023220406.GJ4977@linux.vnet.ibm.com>
 <20141024090857.GA4083@declera.com>
 <20141024154006.GP4977@linux.vnet.ibm.com>
 <20141024162943.GA16621@declera.com>
 <20141024165454.GS4977@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	jay.vosburgh@canonical.com, mroos@linux.ee
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141024165454.GS4977@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri-10/24/14-2014 09:54, Paul E. McKenney wrote:
> On Fri, Oct 24, 2014 at 07:29:43PM +0300, Yanko Kaneti wrote:
> > On Fri-10/24/14-2014 08:40, Paul E. McKenney wrote:
> > > On Fri, Oct 24, 2014 at 12:08:57PM +0300, Yanko Kaneti wrote:
> > > > On Thu-10/23/14-2014 15:04, Paul E. McKenney wrote:
> > > > > On Fri, Oct 24, 2014 at 12:45:40AM +0300, Yanko Kaneti wrote:
> > > > > > 
> > > > > > On Thu, 2014-10-23 at 13:05 -0700, Paul E. McKenney wrote:
> > > > > > > On Thu, Oct 23, 2014 at 10:51:59PM +0300, Yanko Kaneti wrote:
> 
> [ . . . ]
> 
> > > > Ok, unless I've messsed up something major, bisecting points to:
> > > > 
> > > > 35ce7f29a44a rcu: Create rcuo kthreads only for onlined CPUs
> > > > 
> > > > Makes any sense ?
> > > 
> > > Good question.  ;-)
> > > 
> > > Are any of your online CPUs missing rcuo kthreads?  There should be
> > > kthreads named rcuos/0, rcuos/1, rcuos/2, and so on for each online CPU.
> > 
> > Its a Phenom II X6. With 3.17 and linux-tip with 35ce7f29a44a reverted, the rcuos are 8
> > and the modprobe ppp_generic testcase reliably works, libvirt also manages
> > to setup its bridge.
> > 
> > Just with linux-tip , the rcuos are 6 but the failure is as reliable as
> > before.

 
> Thank you, very interesting.  Which 6 of the rcuos are present?

Well, the rcuos are 0 to 5. Which sounds right for a 6 core CPU like this   
Phenom II.

 
> > Awating instructions: :)
> 
> Well, I thought I understood the problem until you found that only 6 of
> the expected 8 rcuos are present with linux-tip without the revert.  ;-)
> 
> I am putting together a patch for the part of the problem that I think
> I understand, of course, but it would help a lot to know which two of
> the rcuos are missing.  ;-)
>

Ready to test

--Yanko
