From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig invokes undefined behaviour
Date: Sun, 6 Feb 2005 22:45:40 -0800
Message-ID: <20050206224540.5b5dc590.davem@davemloft.net>
References: <20050206044744.GO20386@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20050206044744.GO20386@parcelfarce.linux.theplanet.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 6 Feb 2005 04:47:44 +0000
Matthew Wilcox <matthew@wil.cx> wrote:

> strcpy is undefined if src and dest overlap.  That's clearly possible
> here with a sufficiently deep path on the server.  Use memmove instead.
> 
> Signed-off-by: Matthew Wilcox <matthew@wil.cx>

Thanks a lot Matthew, applied to both 2.4.x and 2.6.x
