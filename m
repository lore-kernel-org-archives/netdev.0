From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: msleep_interruptible() in ethtool ioctl and keyboard input
Date: Fri, 29 Apr 2005 12:07:12 -0700
Message-ID: <5fc59ff30504291207424e6166@mail.gmail.com>
References: <468F3FDA28AA87429AD807992E22D07E05195E08@orsmsx408>
	 <29495f1d050429114048da1847@mail.gmail.com>
Reply-To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
In-Reply-To: <29495f1d050429114048da1847@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 
> You really want this timer to go off immediately?
> 
Yes.

> Regardless....
> 
> >         msleep_interruptible(data * 1000);
> 
> Does the same issue occur if you revert this change and make it
> 
> set_current_state(TASK_INTERRUPTIBLE);
> schedule_timeout(data * HZ);
> 
> ?
No. The issue happens irrespective of whether it is
msleep_interruptible or the set_current_state/schedule_timeout combo.

ganesh.
