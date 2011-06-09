From: Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
Subject: Re: [PATCH 2/3] net: msm_ipc: Add user-space support for MSM_IPC
 Router
Date: Thu, 09 Jun 2011 11:06:18 -0600
Message-ID: <4DF0FD8A.1000304@codeaurora.org>
References: <1307555467-1530-1-git-send-email-kramasub@codeaurora.org> <20110609.001149.2112721409565728649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20110609.001149.2112721409565728649.davem@davemloft.net>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/9/2011 1:11 AM, David Miller wrote:
>
> There is no reason to create a whole new socket address family, use
> genetlink instead.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The prospect of using NETLINK sockets was investigated and it seems to 
be supporting the communication between user-space and kernel-space 
processes.

One of the requirements/goals for this MSM_IPC Router is to enable the 
communication between the processes running on different processors & 
OSes, and the addressing mechanism of NETLINK sockets is insufficient to 
address the processes running in different processors and OSes.

We also have the requirements of built-in name service, remote process's 
status detection, location transparency etc. That is the reason for this 
home-grown solution with a requirement for new socket address family.

Please let me know if you need any other information.

Thanks and Regards,
Karthik.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
