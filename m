From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH] [-MM,
 FIX V4] e1000e: incorporate napi_struct changes from net-2.6.24.git
Date: Mon, 17 Sep 2007 21:33:04 +0200
Message-ID: <46EED670.60107@gmail.com>
References: <20070910233503.19058.29051.stgit@localhost.localdomain>
	<46EE5FA1.3080501@gmail.com> <46EEAB79.4040306@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, jeff@garzik.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46EEAB79.4040306@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 09/17/2007 06:29 PM, Kok, Auke wrote:
> Jiri Slaby wrote:
>> On 12/23/-28158 08:59 PM, Auke Kok wrote:
>>> This incorporates the new napi_struct changes into e1000e. Included
>>> bugfix for ifdown hang from Krishna Kumar for e1000.
>>>
>>> Disabling polling is no longer needed at init time, so remove
>>> napi_disable() call from _probe().
>>>
>>> This also fixes an endless polling loop where the driver signalled
>>> "polling done" improperly back to the stack.
>>>
>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Tested-by: Jiri Slaby <jirislaby@gmail.com>

>>> ---
>>>
>>>  drivers/net/e1000e/e1000.h  |    2 ++
>>>  drivers/net/e1000e/netdev.c |   40 ++++++++++++++++------------------------
>>>  2 files changed, 18 insertions(+), 24 deletions(-)
[...]
> I have no lockups here as well anymore, so I'm wondering if you accidentally used
> V3 of the patch.

And so am I, it works, I ported one change to e1000 (non-e) driver and missed
the return 0; removal. Fixed both of them now, so one of them caused it.

thanks a lot,
-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
