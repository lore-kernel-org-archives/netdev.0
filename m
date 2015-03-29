From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: remove
 vmbus_are_subchannels_present() in rndis_filter_device_add()
Date: Sun, 29 Mar 2015 13:15:23 -0700 (PDT)
Message-ID: <20150329.131523.1815681425559014616.davem@davemloft.net>
References: <1427412058-23712-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1427412058-23712-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu, 26 Mar 2015 16:20:58 -0700

> The vmbus_are_subchannels_present() also involves opening the channels, which
> may be too early at this point. Checking for subchannels is not necessary here.
> So this patch removes it. Subchannels will be opened when offer messages arrive.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
