From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/4] bitops: Introduce generic set_bit_le()
Date: Mon, 11 Jun 2012 14:10:26 +0000
Message-ID: <201206111410.26359.arnd@arndb.de>
References: <20120611212735.f92ea521.yoshikawa.takuya@oss.ntt.co.jp> <20120611213101.5969fde5.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, grundler@parisc-linux.org,
	avi@redhat.com, mtosatti@redhat.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	kvm@vger.kernel.org, takuya.yoshikawa@gmail.com
To: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120611213101.5969fde5.yoshikawa.takuya@oss.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 11 June 2012, Takuya Yoshikawa wrote:
> From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
> 
> Needed to replace test_and_set_bit_le() in virt/kvm/kvm_main.c which is
> being used for this missing function.
> 
> Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
> Cc: Arnd Bergmann <arnd@arndb.de>

I would recommend adding the corresponding clear_bit_le() along with
set_bit_le, so the next person who needs that doesn't have to make
yet another patch.

	Arnd
