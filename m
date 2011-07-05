From: Guenter Roeck <guenter.roeck@ericsson.com>
Subject: Re: [PATCH RFC] igb: Fix false positive return of
 igb_get_auto_rd_done for 82580
Date: Tue, 5 Jul 2011 07:31:05 -0700
Message-ID: <20110705143105.GA27454@ericsson.com>
References: <1308682969-20690-1-git-send-email-guenter.roeck@ericsson.com>
	<1308691047.22851.60.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	Tong Ho <tong.ho@ericsson.com>, "Ronciak, John" <john.ronciak@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1308691047.22851.60.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2011 at 05:17:26PM -0400, Jeff Kirsher wrote:
> On Tue, 2011-06-21 at 12:02 -0700, Guenter Roeck wrote:
> > From: Tong Ho <tong.ho@ericsson.com>
> > 
> > 82580 re-reads the port specific portion of eeprom after port reset.
> > If called immediately after a reset, igb_get_auto_rd_done() returns
> > false positive because the done bit has yet to transition from 1 to 0.
> > 
> > Add wrfl() immediately after resetting 82580 port or device,
> > plus a 1ms delay, to avoid the problem.
> > 
> > Signed-off-by: Tong Ho <tong.ho@ericsson.com>
> > Signed-off-by: Guenter Roeck <guenter.roeck@ericsson.com>
> > ---
> > Sent as RFC since I am not entirely sure if the solution is the
> > correct one
> > to address the problem we are seeing. If there is a better solution,
> > please
> > let me know. 
> 
> Thank you for the suggested patch.  Carolyn is the maintainer for igb
> and we will look into this issue you are seeing and the suggested fix. 

Hi Jeff and Carolyn,

Any update ?

Thanks,
Guenter

------------------------------------------------------------------------------
All of the data generated in your IT infrastructure is seriously valuable.
Why? It contains a definitive record of application performance, security 
threats, fraudulent activity, and more. Splunk takes this data and makes 
sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-d2d-c2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
