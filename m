From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v2 4/4] virtio-net: initial debugfs support,
	export mergeable rx buffer size
Date: Mon, 13 Jan 2014 11:19:12 -0800
Message-ID: <CANJ5vPLYJJ1=PVp9LD-4pY2Y9gzk5HROEn_c85pbO4mZkeKA_g@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-4-git-send-email-mwdalton@google.com>
	<52CCF177.7020500@redhat.com> <20140108192109.GC18312@redhat.com>
	<CANJ5vP+Qxa5j_Cp1FBK-qdO+U+dy2kiY5N2bmWdMKbCoY9EwDQ@mail.gmail.com>
	<20140112170939.GA17202@redhat.com>
	<CANJ5vP+Vu8=haCetZkcefPgR8pGe0iDZ03EZhJHLSgunCaHJsQ@mail.gmail.com>
	<20140113094018.GA22726@redhat.com>
	<1389627488.2025.134.camel@bwh-desktop.uk.level5networks.com>
	<CANJ5vPLamPonELhzEEs_e+BQUDrY0w=KpwpzSwGpG551rnbfbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vPLamPonELhzEEs_e+BQUDrY0w=KpwpzSwGpG551rnbfbQ@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Sorry I missed this important piece of information, it appears that
netdev_queue (the TX equivalent of netdev_rx_queue) already has
decoupled itself from CONFIG_XPS due to an attribute,
queue_trans_timeout, that does not depend on XPS functionality. So it
seems that something somewhat equivalent has already happened on the
TX side.

Best,

Mike
