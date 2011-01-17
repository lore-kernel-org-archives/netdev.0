From: Rob Landley <rlandley@parallels.com>
Subject: Re: [PATCH v3 00/16] make rpc_pipefs be mountable multiple time
Date: Mon, 17 Jan 2011 06:30:16 -0600
Message-ID: <4D343658.1020205@parallels.com>
References: <1295012954-7769-1-git-send-email-kas@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Pavel Emelyanov <xemul@parallels.com>,
	<linux-nfs@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	<containers@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Kirill A. Shutemov" <kas@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295012954-7769-1-git-send-email-kas@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/14/2011 07:48 AM, Kirill A. Shutemov wrote:
> Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> Only for client for now.

Ok, Google is being really unhelpful here.

What is rpc_pipefs for?  What uses it, and to do what exactly?  Is it
used by nfs server code, or by the client code, or both?  Is it a way
for userspace to talk to the kernel, or for the kernel to talk to
itself?  Is it used at mount time, or during filesystem operation?

I'm interested in giving this patch series a much more thorough review,
but I can't figure out what the subsystem it's modifying actually _is_.

(Maybe this is something to do with filesystems/nfs/rpc-cache.txt?)

Rob
