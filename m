From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH]  e100: Enable receiving bogus packets, and transmitting bad/custom CRC
Date: Tue, 25 Nov 2003 15:56:12 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125155612.C1107@sygehus.dk>
References: <3FC2931B.3070903@candelatech.com> <20031124152933.1420f6cf.davem@redhat.com> <3FC298C9.8080302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <3FC298C9.8080302@candelatech.com>; from greearb@candelatech.com on Mon, Nov 24, 2003 at 03:48:25PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2003 at 03:48:25PM -0800, Ben Greear wrote:
> 
> So, RX-ALL can be one flag, another for RX-FCS, and the TX-CUSTOM-FCS
> can be a separate patch altogether?

Yes. For example, the i82586 can support RX-ALL but not RX-FCS, and
TX-CUSTOM-FCS would be more work than with i82596 and i82557/8/9. Since the
i82586 has a global (as opposed to per TX cmd) TX-CUSTOM-FCS flag, it would
be necessary to send a configure command whenever this flag changes from one
TX skb to another. So yes, please separate these features.

-- 
Regards,
Rask Ingemann Lambertsen
