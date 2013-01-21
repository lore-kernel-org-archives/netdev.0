From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] iwlegacy: don't return zero on failure paths in
 il4965_pci_probe()
Date: Mon, 21 Jan 2013 11:41:54 +0100
Message-ID: <20130121104153.GA5424@redhat.com>
References: <1358600194-20371-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ilw@linux.intel.com,
	ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358600194-20371-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 19, 2013 at 04:56:34PM +0400, Alexey Khoroshilov wrote:
> If hardware is not ready, il4965_pci_probe() breaks off initialization,
> deallocates all resources, but returns zero.
> The patch adds -EIO as return value in this case.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

ACK
