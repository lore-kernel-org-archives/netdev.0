From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: Fix problems around fdb entries
 pointing to the bridge device
Date: Tue, 09 Aug 2016 21:51:28 -0700 (PDT)
Message-ID: <20160809.215128.1552128338274030624.davem@davemloft.net>
References: <1470276679-5533-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, nikolay@cumulusnetworks.com
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1470276679-5533-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Thu,  4 Aug 2016 11:11:19 +0900

> Adding fdb entries pointing to the bridge device uses fdb_insert(),
> which lacks various checks and does not respect added_by_user flag.
> 
> As a result, some inconsistent behavior can happen:
> * Adding temporary entries succeeds but results in permanent entries.
> * Same goes for "dynamic" and "use".
> * Changing mac address of the bridge device causes deletion of
>   user-added entries.
> * Replacing existing entries looks successful from userspace but actually
>   not, regardless of NLM_F_EXCL flag.
> 
> Use the same logic as other entries and fix them.
> 
> Fixes: 3741873b4f73 ("bridge: allow adding of fdb entries pointing to the bridge device")
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied, thanks.
