From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH net-next] bridge: avoid unnecessary read of
	jiffies
Date: Tue, 7 Feb 2017 17:56:59 +0100
Message-ID: <b6bf4265-bc9c-a54f-953e-0a23bfcb656b@cumulusnetworks.com>
References: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
	<1486227909-18319-5-git-send-email-nikolay@cumulusnetworks.com>
	<20170207084646.70dc888a@xeon-e3>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170207084646.70dc888a@xeon-e3>
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

On 07/02/17 17:46, Stephen Hemminger wrote:
> 
> Jiffies is volatile so read it once.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  net/bridge/br_fdb.c   | 6 ++++--
>  net/bridge/br_input.c | 6 ++++--
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 

Yep, good catch. Maybe you can use READ_ONCE() even though it's not needed just
to show why it's done this way.

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
