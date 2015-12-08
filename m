From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: vsock: select CONFIG_VHOST
Date: Tue, 08 Dec 2015 12:13:56 -0500 (EST)
Message-ID: <20151208.121356.1131159668858222040.davem@davemloft.net>
References: <36261336.7BBY96nNaM@wuerfel>
	<20151208180529-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, stefanha@redhat.com,
	asias@redhat.com
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20151208180529-mutt-send-email-mst@redhat.com>
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

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 8 Dec 2015 18:09:44 +0200

> On Tue, Dec 08, 2015 at 04:46:08PM +0100, Arnd Bergmann wrote:
>> When building the new vsock code without vhost, we get a build error:
>> 
>> drivers/built-in.o: In function `vhost_vsock_flush':
>> :(.text+0x24d29c): undefined reference to `vhost_poll_flush'
>> 
>> This adds an explicit 'select' like we have for the other vhost
>> drivers.
>> 
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> This will need to be done eventually, so
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> but I really think the right thing for now is to revert current vsock
> code, or disable building it unconditionally.  Stefan, could you please
> send a patch like this?

I'm waiting for the full single revert patch and will apply it as
soon as I receive it.
