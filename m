From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH][-next] nfp: don't dereference a null nn->eth_port to
 print a warning
Date: Thu, 6 Apr 2017 16:15:27 -0700
Message-ID: <20170406161527.55b1fd07@cakuba>
References: <20170406125435.18898-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170406125435.18898-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu,  6 Apr 2017 13:54:35 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> On the case where nn->eth_port is null the warning message
> is printing the port by dereferencing this null pointer.
> Remove the deference to avoid a crash when printing the
> warning message.
> 
> Detected by CoverityScan, CID#1426198 ("Dereference after null check")
> 
> Fixes: ce22f5a2cbe3c627 ("nfp: separate high level and low level NSP headers")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Thanks!
