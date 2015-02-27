From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Implement netvsc_get_channels() ethool op
Date: Fri, 27 Feb 2015 15:55:42 +0000
Message-ID: <BN1PR0301MB07707394E47A7808173A6F87CA150@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1424996834-6684-1-git-send-email-andrew@schwartzmeyer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "keithd@vandals.uidaho.edu" <keithd@vandals.uidaho.edu>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "hall5714@vandals.uidaho.edu" <hall5714@vandals.uidaho.edu>
To: Andrew Schwartzmeyer <andrew@schwartzmeyer.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1424996834-6684-1-git-send-email-andrew@schwartzmeyer.com>
Content-Language: en-US
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



> -----Original Message-----
> From: Andrew Schwartzmeyer [mailto:andrew@schwartzmeyer.com]
> Sent: Thursday, February 26, 2015 7:27 PM
> To: Haiyang Zhang
> Cc: KY Srinivasan; devel@linuxdriverproject.org; netdev@vger.kernel.org;
> linux-kernel@vger.kernel.org; hall5714@vandals.uidaho.edu;
> keithd@vandals.uidaho.edu; doma8101@vandals.uidaho.edu;
> andrew@schwartzmeyer.com
> Subject: [PATCH net-next] hyperv: Implement netvsc_get_channels() ethool
> op
> 
> This adds support for reporting the actual and maximum combined channels
> count of the hv_netvsc driver via 'ethtool --show-channels'.
> 
> This required adding 'max_chn' to 'struct netvsc_device', and assigning
> it 'rsscap.num_recv_que' in 'rndis_filter_device_add'. Now we can access
> the combined maximum channel count via 'struct netvsc_device' in the
> ethtool callback.
> 
> Signed-off-by: Andrew Schwartzmeyer <andrew@schwartzmeyer.com>

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Thank you!
