From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/3] r8169: Large Send enablement
Date: Tue, 02 Nov 2004 14:50:59 -0500
Message-ID: <4187E523.4090402@pobox.com>
References: <200411021203.22003.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200411021203.22003.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason wrote:
> This patch enables driver support of MTUs greater than 1500.  Though the 
> adapter documentation says that maximum MTU is 16k, the largest packet I 
> could send was 7440.  So, I am setting that as the max mtu until I can figure 
> out why the adapter misbehaves with packets larger than 7440.

this is dependent on hardware FIFO sizes...
