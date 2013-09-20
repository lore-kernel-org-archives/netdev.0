From: Bastian Blank <bastian@waldi.eu.org>
Subject: Re: [PATCH net-next v2 2/2] xen-netback: handle
 frontends that fail to transition through Closing
Date: Fri, 20 Sep 2013 18:14:31 +0200
Message-ID: <20130920161431.GA19095@mail.waldi.eu.org>
References: <1379685460-25032-1-git-send-email-paul.durrant@citrix.com>
	<1379685460-25032-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>, xen-devel@lists.xen.org
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <1379685460-25032-3-git-send-email-paul.durrant@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 20, 2013 at 02:57:40PM +0100, Paul Durrant wrote:
> Some old Windows frontends fail to transition through the xenbus Closing
> state and move directly from Connected to Closed. Handle this case properly.

What happens in this case? Are there other state changes that will do
unwanted things?

Bastian

-- 
If there are self-made purgatories, then we all have to live in them.
		-- Spock, "This Side of Paradise", stardate 3417.7
