From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network
	device driver.
Date: Wed, 10 May 2006 20:28:22 +0200
Message-ID: <200605102028.22974.ak@suse.de>
References: <20060509084945.373541000@sous-sol.org>
	<6a1855ab01a195ac2a28a97c5f966f67@cl.cam.ac.uk>
	<ada1wv3apu0.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, Ian Pratt <ian.pratt@xensource.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Wright <chrisw@sous-sol.org>, virtualization@lists.osdl.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <ada1wv3apu0.fsf@cisco.com>
Content-Disposition: inline
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Tuesday 09 May 2006 22:46, Roland Dreier wrote:
>     Keir> Where should we get our entropy from in a VM environment?
>     Keir> Leaving the pool empty can cause processes to hang.
>
> You could have something like a virtual HW RNG driver (with a frontend
> and backend), which steals from the dom0 /dev/random pool.

They already have a vTPM - iirc TPMs support random numbers so
that could be used. But it's probably complicated to use.

But if sampling virtual events for randomness is really unsafe (is it 
really?) then native guests in Xen would also get bad random numbers
and this would need to be somehow addressed.

I haven't seen real evidence yet why the virtual events should 
provide less randomness than the hardware.

-And
