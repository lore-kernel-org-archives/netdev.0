From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Tue, 12 Feb 2013 19:21:23 -0800 (PST)
Message-ID: <391933308.1119093.1360725683160.JavaMail.root@vmware.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
	<5118FEA9.2080201@redhat.com>
	<1675407061.963254.1360682467627.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1675407061.963254.1360682467627.JavaMail.root@vmware.com>
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

> stream_has_data: Returns amount of data available (in bytes) in the
> socket's receive buffer, or -1 if empty.
> 
> stream_has_space: Returns amount of space available (in bytes) in the
> socket's send buffer, or -1 if full.

Actually, I think it's for empty/full, and -1 for an error (say, the
transport closed or whatever).

Thanks!
- Andy
