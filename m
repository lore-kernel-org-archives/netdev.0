From: Venkatesh Srinivas via Virtualization
	<virtualization@lists.linux-foundation.org>
Subject: Re: [PATCH v2] vhost: replace % with & on data path
Date: Fri, 4 Dec 2015 12:19:01 -0800
Message-ID: <20151204201901.GB19430@google.com>
References: <1448874894-18398-1-git-send-email-mst@redhat.com>
Reply-To: Venkatesh Srinivas <venkateshs@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1448874894-18398-1-git-send-email-mst@redhat.com>
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

On Mon, Nov 30, 2015 at 11:15:23AM +0200, Michael S. Tsirkin wrote:
> We know vring num is a power of 2, so use &
> to mask the high bits.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---

The generated code switches from DIV -> masking, source is clearer as well.

Tested-by: Venkatesh Srinivas <venkateshs@google.com>

-- vs;
