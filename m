From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Wed, 1 Jun 2005 14:41:23 -0700
Message-ID: <20050601144123.2bc11c06@dxpl.pdx.osdl.net>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	<20050531105939.7486e071@dxpl.pdx.osdl.net>
	<92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
	Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Jun 2005 15:45:26 -0500
Andy Fleming <afleming@freescale.com> wrote:

> 
> On May 31, 2005, at 12:59, Stephen Hemminger wrote:
> 
> > Here are some patches:
> >     * allow phy's to be modules
> >     * use driver owner for ref count
> >     * make local functions static where ever possible
> 
> I agree with all these.
> 
> >     * get rid of bus read may sleep implication in comment.
> >       since you are holding phy spin lock it better not!!
> 

On a different note, I am not sure that using sysfs/kobject bus object
is the right thing for this object.  Isn't the phy instance really just
an kobject whose parent is the network device?  I can't see a 1 to N
relationship between phy bus and phy objects existing. 

The main use I can see for being a driver object is to catch suspend/resume,
and wouldn't you want that to be tied to the network device.
