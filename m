From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Thu, 18 Nov 2004 14:16:33 -0800
Message-ID: <OFE512064F.DBA4A3CD-ON88256F50.007A2A62-88256F50.007A5E0F@us.ibm.com>
References: <20041118220719.GA9890@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "Chad N. Tindel" <chad@tindel.net>, linux-net@vger.kernel.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041118220719.GA9890@gondor.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Isn't the read itself atomic?

Assuming so, another solution would be to stat/fstat the file, add some to 
it to account
for growth, allocate a buffer that big and read the whole thing in one 
shot. Then the
results should be self-consistent.

                                                +-DLS
