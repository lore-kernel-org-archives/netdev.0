From: David Miller <davem@davemloft.net>
Subject: Re: [net v2] e1000: Fix driver to be used on PA RISC C8000
 workstations
Date: Tue, 30 Aug 2011 20:59:09 -0400 (EDT)
Message-ID: <20110830.205909.609067631955528716.davem@davemloft.net>
References: <1314751777-13772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, gmsoft@tuxicoman.be,
        gospo@redhat.com, eike-kernel@sf-tec.de, mattst88@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <1314751777-13772-1-git-send-email-jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
 <mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
 <mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Aug 2011 17:49:37 -0700

> The checksum field in the EEPROM on HPPA is really not a
> checksum but a signature (0x16d6).  So allow 0x16d6 as the
> matching checksum on HPPA systems.
> 
> This issue is present on longterm/stable kernels, I have
> verified that this patch is applicable back to at least
> 2.6.32.y kernels.
> 
> v2- changed ifdef to use CONFIG_PARISC instead of __hppa__
> 
> CC: Guy Martin <gmsoft@tuxicoman.be>
> CC: Rolf Eike Beer <eike-kernel@sf-tec.de>
> CC: Matt Turner <mattst88@gmail.com>
> Reported-by: Mikulas Patocka <mikulas@artax.kerlin.mff.cuni.cz>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

Applied, thanks Jeff.

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable
