From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Thu, 14 Apr 2016 02:55:22 +0200
Message-ID: <20160414005522.GA2975@worktop.cust.blueprintrf.com>
References: <1408683665.5648.69.camel@marge.simpson.net>
 <20140822073653.GA7372@gmail.com>
 <53F70887.8030602@redhat.com>
 <1408716976.5604.18.camel@edumazet-glaptop2.roam.corp.google.com>
 <53FB3715.7070009@linux.intel.com>
 <53FC3466.8000304@redhat.com>
 <5404186E.4090409@linux.intel.com>
 <54053AF8.6070907@redhat.com>
 <54055D9F.7000108@linux.intel.com>
 <54056459.4060100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com,
	"Ingo Molnar jacob.e.keller@intel.com" <mingo@elte.hu>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54056459.4060100@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 02, 2014 at 02:31:53PM +0800, Jason Wang wrote:
> Yes, but current code can not do this. In most of the cases, the new
> woke up process have no chance to run if another process is busy loop in
> the same cpu.

That sounds weird; a process that slept will have an effective vruntime
deficit vs one that has been running for a while.
