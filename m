From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware
 Clock instead of the timecompare method
Date: Tue, 27 Mar 2012 14:39:29 -0400
Message-ID: <CAAsGZS7rUBMW6JK5q2U=7oJy7s2jL0QHAL2z-+9Rm+yM1a5_Kg@mail.gmail.com>
References: <02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
	<20120322064107.GB2182@netboy.at.omicron.at>
	<CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
	<20120324065147.GB2201@netboy.at.omicron.at>
	<CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
	<20120326152730.GA10212@localhost.localdomain>
	<CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
	<20120327153345.GA13948@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>, "Keller,
	Jacob E" <jacob.e.keller@intel.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120327153345.GA13948@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2012 at 11:33 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Mon, Mar 26, 2012 at 01:11:32PM -0400, chetan loke wrote:
>>
>> Why isn't ioctl-rate limiting acceptable?
>
> Let me turn the question around.
>
> What other kernel subsystem rate limits ioctls?
>

netdev needs to worry about reaching the host via ethernet. If you
lose SCSI LUNs because you are pounding those mailbox cmds to get that
temperature status from the HBA then who the heck cares? I mean we do
but we can reach the host via it's mgmt-IP and look at it. From what I
can see in SCSI for example, control commands are normally issued in
separate paths by the driver and don't choke the fast path. Those
completions are asynchronous like everything else and do NOT contend
with the Rx/Tx path.

May be I'm paranoid but let's wait for Intel(Jake) to run the ioctl test.

Chetan

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
