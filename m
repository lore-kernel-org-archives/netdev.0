From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH 1/2] virtio-net: determine type of bufs correctly
Date: Thu, 5 Dec 2013 12:09:44 -0800
Message-ID: <CANJ5vPKoH59JuupkK5+dFD3irp8GQQ7MxCnV2GvPKxNYOXNgdA@mail.gmail.com>
References: <1386254181-17257-1-git-send-email-avagin@openvz.org>
	<1386254181-17257-2-git-send-email-avagin@openvz.org>
	<20131205145217.GA23147@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	lf-virt <virtualization@lists.linux-foundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131205145217.GA23147@redhat.com>
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

Thanks Andrey, great catch. I believe this issue occurs in one more
place, when packets are dropped if they are too short. I will send
out a patch momentarily to fix that additional case.

Best,

Mike
