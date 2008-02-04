From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 4/5] ehea: fix phyp checkpatch complaints
Date: Mon, 04 Feb 2008 12:06:06 -0600
Message-ID: <47A7540E.2010400@freescale.com>
References: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
	<1201832451-23634-5-git-send-email-dwm@austin.ibm.com>
	<20080201192344.GA4541@loki.buserror.net>
	<19294.1201927197@bebe.enoyolf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <themann@de.ibm.com>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@garzik.org>,
	Linux PowerPC List <linuxppc-dev@ozlabs.org>,
	Paul Mackerras <paulus@samba.org>
To: Doug Maxey <dwm@enoyolf.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <19294.1201927197@bebe.enoyolf.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Doug Maxey wrote:
> On Fri, 01 Feb 2008 13:23:45 CST, Scott Wood wrote:
>> On Thu, Jan 31, 2008 at 08:20:50PM -0600, Doug Maxey wrote:
>>>  /* input param R5 */
>>> -#define H_ALL_RES_QP_EQPO         EHEA_BMASK_IBM(9, 11)
> ...
>>> +#define H_ALL_RES_QP_EQPO	  EHEA_BMASK_IBM(9, 11)
> ...
>> This was better the way it was (before, it was readable at any tab setting);
>> checkpatch is overeager to complain on tab/space issues (it's a bit hard to
>> distinguish indentation from alignment with a regex).
> 
> In emacs, with no special offsets, the lines appear to still line up.

Are you using a tab size other than 8?

> What did happen was spaces were turned to tabs where applicable.

I disagree about the applicability. :-)

> What editor shows a bad alignment?

Any editor that has been configured to a non-default tab size.

-Scott
