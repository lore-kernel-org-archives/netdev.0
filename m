From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] resubmit bridge: fix message_age_timer
	calculation
Date: Thu, 12 Sep 2013 23:31:08 -0400 (EDT)
Message-ID: <20130912.233108.685057998121546379.davem@davemloft.net>
References: <1378960667-5092-1-git-send-email-cphealy@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, buytenh@wantstofly.org
To: cphealy@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1378960667-5092-1-git-send-email-cphealy@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Chris Healy <cphealy@gmail.com>
Date: Wed, 11 Sep 2013 21:37:47 -0700

> This changes the message_age_timer calculation to use the BPDU's max age as
> opposed to the local bridge's max age.  This is in accordance with section
> 8.6.2.3.2 Step 2 of the 802.1D-1998 sprecification.
> 
> With the current implementation, when running with very large bridge
> diameters, convergance will not always occur even if a root bridge is 
> configured to have a longer max age.
> 
> Tested successfully on bridge diameters of ~200.
> 
> Signed-off-by: Chris Healy <cphealy@gmail.com>

Applied and queued up for -stable, thanks!
