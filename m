From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Use memset instead of cacheable_memzero
Date: Tue, 28 Apr 2009 08:04:20 -0700 (PDT)
Message-ID: <20090428.080420.86723596.davem@davemloft.net>
References: <1240928041-10905-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: galak@kernel.crashing.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <1240928041-10905-1-git-send-email-galak@kernel.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Kumar Gala <galak@kernel.crashing.org>
Date: Tue, 28 Apr 2009 09:14:01 -0500

> cacheable_memzero() is completely overkill for the clearing out the FCB
> block which is only 8-bytes.  The compiler should easily optimize this
> with memset.  Additionally, cacheable_memzero() only exists on ppc32 and
> thus breaks builds of gianfar on ppc64.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

Applied to net-next-2.6, thanks!
