From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] tipc: revert some previously ABI
 breaking changes to the user space tipc interface
Date: Thu, 21 Oct 2010 09:06:22 -0400
Message-ID: <4CC03ACE.7030308@windriver.com>
References: <1287659176-14504-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net,
	luca@llucax.com.ar
To: nhorman@tuxdriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1287659176-14504-1-git-send-email-nhorman@tuxdriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 10-10-21 07:06 AM, nhorman@tuxdriver.com wrote:
> Based on discussions with Leandro Lucarella and Jon Maloy, it appears we've
> managed to break the TIPC user space ABI.  While it would be really nice to have
> some level of consistency in regards to on the wire byte order, we can't do that
> if it breaks user space.  This patch series reverts the offending patches that
> caused this, and puts us back in a state that allows user space to work
> properly.  We can now go back and look at methods to get consistent on the wire
> byte order while maintaining host byte order in the user space API.

Thanks Neil for working with Jon and Leandro on this and getting
a fix out quickly (faster than I could have, for sure.)

Paul.

> 
> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>


------------------------------------------------------------------------------
Nokia and AT&T present the 2010 Calling All Innovators-North America contest
Create new apps & games for the Nokia N8 for consumers in  U.S. and Canada
$10 million total in prizes - $4M cash, 500 devices, nearly $6M in marketing
Develop with Nokia Qt SDK, Web Runtime, or Java and Publish to Ovi Store 
http://p.sf.net/sfu/nokia-dev2dev
