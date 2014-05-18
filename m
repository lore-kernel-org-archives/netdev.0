From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH] net/mlx4_en: Fix uninitialized use of 'port_up' in mlx4_en_set_channels()
Date: Sun, 18 May 2014 14:43:45 +0300
Message-ID: <53789CF1.5040402@mellanox.com>
References: <1400363523-18371-1-git-send-email-cengelma@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Christian Engelmayer <cengelma@gmx.at>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400363523-18371-1-git-send-email-cengelma@gmx.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/18/2014 12:52 AM, Christian Engelmayer wrote:
> Function mlx4_en_set_channels() stops running ports before performing the
> requested action. In that case local variable 'port_up' is set so that the
> port is restarted at the end of the function, however, in case the port was
> not stopped, variable 'port_up' is left uninitialized and the behaviour is
> undetermined. Detected by Coverity - CID 751497.
>
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
> ---

Acked-By: Amir Vadai <amirv@mellanox.com>
