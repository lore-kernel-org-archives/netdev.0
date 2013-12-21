From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V2 0/4] misc: xgene: Add support for APM X-Gene SoC Queue
 Manager/Traffic Manager
Date: Sat, 21 Dec 2013 21:11:40 +0100
Message-ID: <201312212111.40576.arnd@arndb.de>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, jcm@redhat.com, gregkh@linuxfoundation.org,
 patches@apm.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 Keyur Chudgar <kchudgar@apm.com>, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Ravi Patel <rapatel@apm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1387594651-25771-1-git-send-email-rapatel@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Saturday 21 December 2013, Ravi Patel wrote:
> This patch adds support for APM X-Gene SoC Queue Manager/Traffic Manager.
>  QMTM is required by APM X-Gene SoC Ethernet, PktDMA (XOR Engine) and
>  Security Engine subsystems. All subsystems communicate with QMTM using
>  messages which include information about the work to be performed and
>  the location of associated data buffers.  

Please describe here what the purpose of the qmtm is, as this is not
entirely clear from the code.

In particular, please describe how this differs from a dmaengine driver
and why it is not possible to extend the dma slave API to describe qmtm
as a dma engine.

	Arnd
