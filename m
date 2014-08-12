From: Razya Ladelsky <razya@il.ibm.com>
Subject: Re: [PATCH] vhost: Add polling mode
Date: Tue, 12 Aug 2014 13:57:05 +0300
Message-ID: <OF93E480CE.EFA0854D-ONC2257D32.003BE092-C2257D32.003C1F49@il.ibm.com>
References: <1407659404-razya@il.ibm.com>
	<20140810083035.0CF58380729@moren.haifa.ibm.com>
	<20140810194559.GA4344@redhat.com>
	<20140811.124621.576073630604147753.davem@davemloft.net>
	<20140812091850.GD6440@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eran Raichstein <ERANRA@il.ibm.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, abel.gordon@gmail.com,
	Alex Glikson <GLIKSON@il.ibm.com>, Yossi Kuperman1 <YOSSIKU@il.ibm.com>,
	Joel Nider <JOELN@il.ibm.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140812091850.GD6440@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 12/08/2014 12:18:50 PM:

> From: "Michael S. Tsirkin" <mst@redhat.com>
> To: David Miller <davem@davemloft.net>
> Cc: Razya Ladelsky/Haifa/IBM@IBMIL, kvm@vger.kernel.org, Alex 
> Glikson/Haifa/IBM@IBMIL, Eran Raichstein/Haifa/IBM@IBMIL, Yossi 
> Kuperman1/Haifa/IBM@IBMIL, Joel Nider/Haifa/IBM@IBMIL, 
> abel.gordon@gmail.com, linux-kernel@vger.kernel.org, 
> netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
> Date: 12/08/2014 12:18 PM
> Subject: Re: [PATCH] vhost: Add polling mode
> 
> On Mon, Aug 11, 2014 at 12:46:21PM -0700, David Miller wrote:
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> > Date: Sun, 10 Aug 2014 21:45:59 +0200
> > 
> > > On Sun, Aug 10, 2014 at 11:30:35AM +0300, Razya Ladelsky wrote:
> >  ...
> > > And, did your tests actually produce 100% load on both host CPUs?
> >  ...
> > 
> > Michael, please do not quote an entire patch just to ask a one line
> > question.
> > 
> > I truly, truly, wish it was simpler in modern email clients to delete
> > the unrelated quoted material because I bet when people do this they
> > are simply being lazy.
> > 
> > Thank you.
> 
> Lazy - mea culpa, though I'm using mutt so it isn't even hard.
> 
> The question still stands: the test results are only valid
> if CPU was at 100% in all configurations.
> This is the reason I generally prefer it when people report
> throughput divided by CPU (power would be good too but it still
> isn't easy for people to get that number).
> 

Hi Michael,

Sorry for the delay, had some problems with my mailbox, and I realized 
just now that 
my reply wasn't sent.
The vm indeed ALWAYS utilized 100% cpu, whether polling was enabled or 
not.
The vhost thread utilized less than 100% (of the other cpu) when polling 
was disabled.
Enabling polling increased its utilization to 100% (in which case both 
cpus were 100% utilized). 


> -- 
> MST
> 
